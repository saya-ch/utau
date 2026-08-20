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
