#!/usr/bin/env python3
"""Print readable text from a .docx file using only the Python standard library."""

import sys
import xml.etree.ElementTree as ET
import zipfile

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"


def extract(path: str) -> str:
    with zipfile.ZipFile(path) as archive:
        xml = archive.read("word/document.xml")

    root = ET.fromstring(xml)
    paragraphs = []

    for para in root.iter(W + "p"):
        parts = []
        for node in para.iter():
            if node.tag == W + "t" and node.text:
                parts.append(node.text)
            elif node.tag == W + "tab":
                parts.append("\t")
            elif node.tag in (W + "br", W + "cr"):
                parts.append("\n")
        paragraphs.append("".join(parts).strip())

    # Collapse runs of blank paragraphs so the preview pane stays readable.
    cleaned = []
    blanks = 0
    for line in paragraphs:
        if line == "":
            blanks += 1
            if blanks > 1:
                continue
        else:
            blanks = 0
        cleaned.append(line)

    return "\n".join(cleaned)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: extract.py FILE.docx", file=sys.stderr)
        return 2

    try:
        sys.stdout.write(extract(sys.argv[1]))
    except Exception as exc:  # noqa: BLE001 - preview should never crash Yazi
        print(f"Cannot extract DOCX: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
