"""Generate browser R lessons from student QMDs, render and test before Pages release."""
from __future__ import annotations
import argparse
import functools
import hashlib
import http.server
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import yaml

ROOT = Path(__file__).resolve().parents[1]


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value if isinstance(value, str) else json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()


def student_path(root, relative):
    path = (root / relative).resolve()
    path.relative_to((root / 'labs/student').resolve())
    if not path.is_file(): raise ValueError('Missing student source: ' + relative)
    return path


def lessons(root, config):
    result = []
    for session in config['sessions']:
        if session.get('browser_no_practice'):
            continue
        sources = [session['browser_source']] if session.get('browser_source') else [p for p in session.get('labs', []) if p.endswith('.qmd')]
        if len(sources) != 1:
            raise ValueError(session['id'] + ': register one student QMD (or explicit browser_no_practice reason)')
        student_path(root, sources[0])
        result.append((session, sources[0]))
    return result


CHUNK = re.compile(r'^```\{r[^}]*\}\n(.*?)^```\s*$', re.M | re.S)


def adapt(body, session):
    # Section replacements are explicit course decisions, never inferred from private solutions.
    for title, replacement in session.get('browser_sections', {}).items():
        pattern = r'^' + re.escape(title) + r'\n.*?(?=^' + re.escape(title.split(' ')[0]) + r' |\Z)'
        body, n = re.subn(pattern, lambda m: title + '\n\n' + replacement + '\n\n', body, count=1, flags=re.M | re.S)
        if n != 1: raise ValueError('Source heading changed: ' + title)
    for old, new in session.get('browser_graph_labels', {}).items():
        body = body.replace('"' + old + '"', '"' + new + '"')
    cells = []
    def convert(match):
        raw = match[1]
        opts = yaml.safe_load('\n'.join(line[2:].strip() for line in raw.splitlines() if line.startswith('#|'))) or {}
        code = '\n'.join(line for line in raw.splitlines() if not line.startswith('#|')).strip()
        if 'shiny::runApp(' in code:
            return '[코드를 편집하며 Shiny 앱 실행하기](apps/week01/edit/index.html)\n'
        if 'install.packages(' in code or 'Sys.which("quarto")' in code:
            return '데스크톱에서 사용하는 명령입니다. 온라인 실습에서는 실행하지 않습니다.\n\n```r\n' + code + '\n```\n'
        number = len(cells) + 1
        cid = session['id'] + '-' + str(number)
        exercise = opts.get('eval') is False
        cells.append({'id': cid, 'code': code, 'exercise': exercise})
        options = f'#| label: cell-{cid}\n#| autorun: false\n#| persist: true\n'
        if exercise: options += f'#| exercise: ex-{cid}\n'
        return f'::: {{#cell-{cid} .browser-cell}}\n\n```{{webr}}\n' + options + code + '\n```\n\n:::\n'
    body = CHUNK.sub(convert, body)
    return body, cells


def generate(root=ROOT):
    config = yaml.safe_load((root / 'course/course.yml').read_text(encoding='utf-8'))
    settings = config.get('browser', {})
    if not settings.get('enabled'): return None
    browser = root / 'browser'
    if not (browser / '_extensions/r-wasm/live/_extension.yml').exists():
        raise ValueError('Install the pinned Quarto Live extension in browser/')
    entries = lessons(root, config)
    manifest = {'pages': [], 'source_sha256': {}, 'quarto_live_tag': settings['quarto_live_tag'], 'webr': settings['webr_url']}
    navbar = [{'text': '실습 홈', 'href': 'index.qmd'}]
    for s, rel in entries:
        s['browser_url'] = settings['url'].rstrip('/') + '/' + s['id'] + '.html'
        source = student_path(root, rel)
        original = source.read_text(encoding='utf-8-sig')
        body = re.sub(r'\A---\n.*?\n---\n', '', original, count=1, flags=re.S)
        body, cells = adapt(body, {**s, 'browser_graph_labels': settings.get('graph_labels', {})})
        # Resolve only source-local images; preserve original image bytes.
        def asset(m):
            value = m[2]
            if '://' in value: return m[0]
            p = (source.parent / value).resolve()
            p.relative_to(root.resolve())
            if not p.is_file(): raise ValueError('Missing image: ' + value)
            target = browser / 'assets' / (digest(p)[:12] + p.suffix)
            target.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(p, target)
            return m[1] + 'assets/' + target.name + ')'
        body = re.sub(r'(!\[[^\]]*\]\()([^\)]+)\)', asset, body)
        resources = []
        for rel_data in s.get('browser_resources', []):
            data = student_path(root, rel_data)
            dest = browser / 'data' / data.name
            dest.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(data, dest)
            resources.append('data/' + data.name)
            manifest['source_sha256'][rel_data] = digest(data)
        title = s.get('browser_title', s['title'])
        header = {'title': title, 'resources': resources, 'webr': {'resources': resources, 'packages': s.get('browser_packages', [])}}
        intro = ('R 설치나 로그인이 필요 없습니다. 로딩이 끝나면 **Run Code**를 눌러 위에서부터 실행하세요. '
                 '앞 셀의 값을 바꾼 뒤에는 뒤의 계산도 다시 실행해야 합니다. 빈칸·디버깅 문제는 직접 고쳐 실행합니다.\n\n'
                 '<button type="button" id="download-code" class="btn btn-primary">내 R 코드 다운로드</button> '
                 '<button type="button" onclick="location.reload()" class="btn btn-outline-secondary">R 세션 다시 시작</button>\n\n'
                 '실행한 코드는 이 브라우저에 보관됩니다. R 객체는 새로고침 후 다시 만들어야 합니다. '
                 '다른 컴퓨터로 옮기거나 제출할 때는 코드를 다운로드하세요.\n\n'
                 f'[기존 R·QMD 다운로드](https://github.com/{config["repository"]}/tree/main/{source.parent.relative_to(root).as_posix()})\n\n')
        bridge = '\n```{ojs}\n//| echo: false\n//| output: false\ncourseRuntime = { window.courseR = await webROjs.webRPromise; return true; }\n```\n'
        text = '---\n' + yaml.safe_dump(header, allow_unicode=True, sort_keys=False) + '---\n\n{{< include _extensions/r-wasm/live/_knitr.qmd >}}\n\n' + intro + body + bridge
        write(browser / (s['id'] + '.qmd'), text)
        manifest['source_sha256'][rel] = digest(source)
        manifest['pages'].append({'id': s['id'], 'title': title, 'cells': cells, 'checks': s.get('browser_checks', [])})
        navbar.append({'text': s['id'] + ' · ' + title, 'href': s['id'] + '.qmd'})
    project = {'project': {'type': 'website', 'output-dir': '_site', 'render': ['index.qmd'] + [s['id'] + '.qmd' for s, _ in entries]},
               'website': {'title': config['title'] + ' · 온라인 실습', 'site-url': settings['url'], 'navbar': {'left': navbar}},
               'lang': 'ko', 'engine': 'knitr', 'format': {'live-html': {'toc': True, 'embed-resources': False,
               'css': 'course.css', 'include-after-body': 'course.js.html', 'webr': {'engine-url': settings['webr_url']}}}}
    write(browser / '_quarto.yml', yaml.safe_dump(project, allow_unicode=True, sort_keys=False))
    write(browser / 'index.qmd', '---\ntitle: "회귀분석 · 온라인 R 실습"\n---\n\n설치 없이 코드를 수정하고 실행합니다. 각 차시를 열고 로딩 완료 후 **Run Code**를 누르세요.\n\n' + '\n'.join(f'- [{p["title"]}]({p["id"]}.qmd)' for p in manifest['pages']) + '\n\n[강의자료·PDF·다운로드](https://github.com/' + config['repository'] + ')\n')
    write(browser / 'course.css', '.browser-cell{margin:1.5rem 0} .cm-editor{font-size:15px} .btn{margin:0.3rem} .cell-output-display canvas{max-width:100%}\n')
    write(browser / 'course.js.html', '''<script>
document.addEventListener('DOMContentLoaded', () => {
 const button = document.getElementById('download-code');
 if (button) button.addEventListener('click', () => {
  const cells = [...document.querySelectorAll('.browser-cell .cm-content')].map(x => x.innerText);
  const link = document.createElement('a');
  link.href = URL.createObjectURL(new Blob([cells.join('\\n\\n') + '\\n'], {type:'text/plain;charset=utf-8'}));
  link.download = location.pathname.split('/').pop().replace('.html', '') + '-practice.R';
  link.click(); setTimeout(() => URL.revokeObjectURL(link.href), 1000);
 });
});
</script>\n''')
    write(browser / 'manifest.json', manifest)
    write(root / 'course/course.yml', yaml.safe_dump(config, allow_unicode=True, sort_keys=False))
    return manifest


def binary(name):
    found = shutil.which(name)
    if not found and os.name == 'nt':
        if name == 'quarto': found = 'C:/Program Files/Quarto/bin/quarto.exe'
        else:
            found = next(iter(sorted(Path('C:/Program Files/R').glob('R-*/bin/Rscript.exe'), reverse=True)), None)
    if not found or not Path(found).exists(): raise ValueError('Missing tool: ' + name)
    return str(found)


def render(root=ROOT):
    manifest = generate(root)
    if manifest is None: return
    env = os.environ.copy(); env['QUARTO_R'] = str(Path(binary('Rscript')).parent)
    subprocess.run([binary('quarto'), 'render'], cwd=root / 'browser', env=env, check=True)
    config = yaml.safe_load((root / 'course/course.yml').read_text(encoding='utf-8'))
    for app in config['browser'].get('shiny_apps', []):
        original = student_path(root, app['source'])
        with tempfile.TemporaryDirectory(prefix='browser-app-') as folder:
            temp = Path(folder)
            app_code = original.read_text(encoding='utf-8').replace('file.path("..", "data",', 'file.path("data",')
            for old, new in config['browser'].get('graph_labels', {}).items():
                app_code = app_code.replace('"' + old + '"', '"' + new + '"')
            write(temp / 'app.R', app_code)
            (temp / 'data').mkdir()
            for data in app['data']: shutil.copyfile(student_path(root, data), temp / 'data' / Path(data).name)
            target = (root / 'browser/_site/apps' / app['id']).resolve()
            # Export assets only to ignored build output, never to the student Git tree.
            expression = 'shinylive::export(' + json.dumps(temp.as_posix()) + ', ' + json.dumps(target.as_posix()) + ', assets_version="' + config['browser']['shinylive_assets'] + '", template_params=list(components=c("editor", "viewer")))'
            subprocess.run([binary('Rscript'), '-e', expression], check=True)
    commit = os.environ.get('GITHUB_SHA') or subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
    write(root / 'browser/_site/build-info.json', {'commit': commit, 'sources': manifest['source_sha256']})
    print('Browser render complete:', root / 'browser/_site')


def check(root=ROOT, url=None):
    from playwright.sync_api import sync_playwright, expect
    manifest = json.loads((root / 'browser/manifest.json').read_text(encoding='utf-8'))
    server = None
    if not url:
        class QuietHandler(http.server.SimpleHTTPRequestHandler):
            def log_message(self, *args): pass
        handler = functools.partial(QuietHandler, directory=str(root / 'browser/_site'))
        server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), handler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        url = f'http://127.0.0.1:{server.server_port}/'
    results = []
    try:
        with sync_playwright() as pw:
            browser = pw.chromium.launch()
            for lesson in manifest['pages']:
                page = browser.new_page(accept_downloads=True)
                page.goto(url.rstrip('/') + '/' + lesson['id'] + '.html', wait_until='domcontentloaded')
                page.wait_for_function('window.courseR !== undefined', timeout=180000)
                for cell in lesson['cells']:
                    if cell['exercise']: continue
                    # Execute exactly the generated code in the same browser runtime used by editors.
                    page.evaluate('async code => { await window.courseR.evalRVoid(code); }', cell['code'])
                for assertion in lesson['checks']:
                    page.evaluate('async code => { await window.courseR.evalRVoid(code); }', assertion)
                plots = [c for c in lesson['cells'] if not c['exercise'] and re.search(r'\bplot\(', c['code'])]
                if plots:
                    plotcell = page.locator('.browser-cell#cell-' + plots[-1]['id'])
                    plotbutton = plotcell.get_by_role('button', name='Run Code', exact=True)
                    expect(plotbutton).not_to_have_class(re.compile(r'\bdisabled\b'), timeout=60000)
                    plotbutton.click()
                    plotcell.locator('canvas, img').first.wait_for(timeout=60000)
                # Exercise the actual editable UI, not just the runtime API.
                cell = page.locator('.browser-cell').first
                editor = cell.locator('.cm-content').first
                editor.click()
                editor.press('ControlOrMeta+A')
                editor.press_sequentially('print(12345 + 5)', delay=20)
                runbutton = cell.get_by_role('button', name='Run Code', exact=True)
                # Quarto Live disables busy buttons with a CSS class, not a disabled attribute.
                expect(runbutton).not_to_have_class(re.compile(r'\bdisabled\b'), timeout=60000)
                runbutton.click()
                cell.get_by_text('[1] 12350', exact=False).wait_for(timeout=60000)
                with page.expect_download() as download:
                    page.locator('#download-code').click()
                assert '12345 + 5' in Path(download.value.path()).read_text(encoding='utf-8')
                broken = page.evaluate('Array.from(document.images).filter(i=>!i.complete || i.naturalWidth===0).map(i=>i.src)')
                if broken: raise ValueError('Broken images: ' + str(broken))
                results.append({'session': lesson['id'], 'runtime': 'passed', 'editor': 'passed', 'download': 'passed', 'assertions': len(lesson['checks'])})
                page.close()
            config = yaml.safe_load((root / 'course/course.yml').read_text(encoding='utf-8'))
            for app in config['browser'].get('shiny_apps', []):
                page = browser.new_page()
                page.goto(url.rstrip('/') + '/apps/' + app['id'] + '/edit/index.html', wait_until='domcontentloaded')
                frame = page.frame_locator('iframe').first
                prediction = frame.locator('#prediction')
                prediction.get_by_text('112.7', exact=False).wait_for(timeout=180000)
                frame.locator('.irs-handle').click()
                page.keyboard.press('ArrowRight')
                frame.locator('#prediction').get_by_text('128.2', exact=False).wait_for(timeout=30000)
                frame.locator('#regression_plot img').wait_for(timeout=30000)
                if page.locator('.cm-content').count() == 0: raise ValueError('Shiny editor missing')
                page.screenshot(path=str(root / '.build/shiny-verified.png'), full_page=True)
                page.locator('.cm-content').first.fill('library(shiny)\nshinyApp(fluidPage(h2("Browser edit verified")), function(input, output, session) {})')
                page.get_by_role('button', name=re.compile('Re-run app')).click()
                frame.get_by_role('heading', name='Browser edit verified').wait_for(timeout=90000)
                results.append({'app': app['id'], 'slider_prediction': 'passed', 'plot': 'passed', 'editor_rerun': 'passed'})
                page.close()
            browser.close()
        report = {'url': url, 'source_sha256': manifest['source_sha256'], 'results': results}
        write(root / '.build/browser-check.json', report)
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return report
    finally:
        if server: server.shutdown(); server.server_close()


if __name__ == '__main__':
    if hasattr(sys.stdout, 'reconfigure'): sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['generate', 'render', 'check'])
    parser.add_argument('--url')
    args = parser.parse_args()
    if args.action == 'generate': generate()
    elif args.action == 'render': render()
    else: check(url=args.url)
