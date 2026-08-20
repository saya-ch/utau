def test_lint_detects_long_line(tmp_path):
    f = tmp_path / "bad.md"
    f.write_text("a"*121 + "\n", encoding="utf-8")
    import subprocess
    r = subprocess.run(["pwsh","-File","tools/docs-lint.ps1","-Path",str(tmp_path)], capture_output=True, text=True)
    assert r.returncode != 0
    assert "120" in r.stdout or "line-length" in r.stdout.lower()

def test_lint_detects_too_many_lines(tmp_path):
    f = tmp_path / "big.md"
    f.write_text(("x\n"*801), encoding="utf-8")
    import subprocess
    r = subprocess.run(["pwsh","-File","tools/docs-lint.ps1","-Path",str(tmp_path)], capture_output=True, text=True)
    assert r.returncode != 0

def test_handbook_sharding():
    import pathlib, re
    p = pathlib.Path("docs/handbook/polish-patterns")
    files = list(p.glob("9.6.*.md"))
    # 修复后动态打包：完整迁移 113 段，约 2-4 段/文件，需 25-60 个分片（当前 55），保持 <500 硬阈
    assert len(files) >= 25 and len(files) <= 60, f"shards {len(files)} not in [25,60]"
    for f in files:
        lines = f.read_text(encoding="utf-8").splitlines()
        assert len(lines) < 500, f"{f.name} {len(lines)} >=500"
        assert max(len(l) for l in lines) <= 120, f"{f.name} has line >120"
        # 围栏闭合校验
        assert f.read_text(encoding="utf-8").count("```") % 2 == 0, f"{f.name} fence odd"
    idx = p / "index.md"
    assert "9.6.101" in idx.read_text(encoding="utf-8")
    # 全量 113 段校验
    total = sum(len(re.findall(r"^### 9\.6\.", f.read_text(encoding="utf-8"), flags=re.MULTILINE)) for f in files)
    assert total == 113, f"segments {total} !=113"
    # 无截断标记
    assert all("已截断" not in f.read_text(encoding="utf-8") for f in files)


def test_roadmap_no_long_lines():
    import pathlib

    files = list(pathlib.Path("docs/03-product/roadmap").glob("*.md"))
    assert len(files) >= 5, f"roadmap shards {len(files)} <5 (expect index + 4 iter)"
    for f in files:
        for i, l in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            assert len(l) <= 120, f"{f}:{i} len={len(l)}"
        assert len(f.read_text(encoding="utf-8").splitlines()) < 800, f"{f} >=800"
    # ITERATION 315 必须在 301-400
    assert "315" in (pathlib.Path("docs/03-product/roadmap/iter-301-400.md").read_text(encoding="utf-8"))
