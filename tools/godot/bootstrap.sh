#!/usr/bin/env bash
# Godot 引擎 bootstrap 脚本
# 用途：检测本地是否已有 Godot 4.6.3-stable Linux x86_64 二进制，没有则从 GitHub Release 拉取。
# 用法：./tools/godot/bootstrap.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${SCRIPT_DIR}/Godot_v4.6.3-stable_linux.x86_64"
URL_FILE="${SCRIPT_DIR}/godot_release_url.txt"
SHA_FILE="${SCRIPT_DIR}/godot_sha256.txt"

echo "=== Godot 4.6.3 bootstrap ==="

# 1. 检测本地是否已就位
if [[ -x "${TARGET}" ]]; then
	echo "[OK] 已存在 ${TARGET}，跳过下载"
	"${TARGET}" --version
	exit 0
fi

# 2. 读取 URL + SHA256
if [[ ! -f "${URL_FILE}" ]]; then
	echo "[ERR] 缺少 ${URL_FILE}，请先创建 GitHub Release 并填入下载链接"
	echo "      流程：仓库主页 → Releases → New release → 上传 Godot_v4.6.3-stable_linux.x86_64"
	exit 1
fi
URL="$(tr -d '[:space:]' < "${URL_FILE}")"
if [[ -z "${URL}" ]]; then
	echo "[ERR] ${URL_FILE} 为空"
	exit 1
fi

EXPECTED_SHA=""
if [[ -f "${SHA_FILE}" ]]; then
	EXPECTED_SHA="$(tr -d '[:space:]' < "${SHA_FILE}")"
fi

# 3. 下载
TMP_ZIP="$(mktemp --suffix=.zip)"
echo "[..] 下载: ${URL}"
if ! curl -fL --retry 3 --connect-timeout 10 -o "${TMP_ZIP}" "${URL}"; then
	echo "[ERR] 下载失败（沙箱外发带宽可能受限，请参考 tools/godot/README.md）"
	rm -f "${TMP_ZIP}"
	exit 1
fi

# 4. SHA256 校验
if [[ -n "${EXPECTED_SHA}" ]]; then
	ACTUAL_SHA="$(sha256sum "${TMP_ZIP}" | awk '{print $1}')"
	if [[ "${ACTUAL_SHA}" != "${EXPECTED_SHA}" ]]; then
		echo "[ERR] SHA256 不匹配: 期望 ${EXPECTED_SHA}，实际 ${ACTUAL_SHA}"
		rm -f "${TMP_ZIP}"
		exit 1
	fi
	echo "[OK] SHA256 校验通过: ${ACTUAL_SHA}"
else
	echo "[WARN] 未提供 SHA256，跳过校验"
fi

# 5. 解压（zip 内部可能直接是 binary，也可能包在文件夹里）
echo "[..] 解压 ${TMP_ZIP}"
WORK_DIR="$(mktemp -d)"
unzip -q "${TMP_ZIP}" -d "${WORK_DIR}"

BIN_PATH="$(find "${WORK_DIR}" -type f -name 'Godot_v4.6.3-stable_linux.x86_64' | head -1)"
if [[ -z "${BIN_PATH}" ]]; then
	echo "[ERR] zip 内未找到 Godot_v4.6.3-stable_linux.x86_64 binary"
	rm -rf "${WORK_DIR}" "${TMP_ZIP}"
	exit 1
fi

mv "${BIN_PATH}" "${TARGET}"
chmod +x "${TARGET}"
rm -rf "${WORK_DIR}" "${TMP_ZIP}"

# 6. 验证
echo "[OK] 已就位: ${TARGET}"
"${TARGET}" --version
