#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Execute actual patched Samsung runInference tail with production gate adapter."""
import ast
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parent.parent
json_jar = Path(os.environ['JSON_JAR']).resolve()
smali = Path(sys.argv[1]).resolve()
wrapper_path = (Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else
                smali.with_name('GatingModelFactory$GatingModelWrapper.smali'))
wrapper = wrapper_path.read_text()
method = wrapper.index('.method public runInference(')
body = wrapper[method:wrapper.index('.end method', method)]
assert body.index('->buildMapUrlGatingLabels(') < body.index('->plus(') < body.index('->extend('), 'fallback must run after Samsung map URL labels are combined'
# Reuse only the literal platform fake definitions, without running that test runner.
module = ast.parse((root / 'validation/run_map_gate_adapter.py').read_text())
stubs = next(ast.literal_eval(node.value) for node in module.body
             if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'stubs' for t in node.targets))
with tempfile.TemporaryDirectory(prefix='nudge-map-pipeline-') as temporary:
    work = Path(temporary)
    sources = []
    for name, source in stubs.items():
        path = work / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source)
        sources.append(str(path))
    sources.extend(str(root / 'client-java/io/mesalabs/rezoss/ai' / name)
                   for name in ['NativeMapGate.java', 'MapGateContract.java'])
    sources.append(str(root / 'validation/MapGatePipelineTest.java'))
    subprocess.run(['javac', '-Xlint:all', '-Werror', '-cp', str(json_jar), '-d', str(work), *sources], check=True)
    subprocess.run(['java', '-cp', f'{work}:{json_jar}', 'io.mesalabs.rezoss.ai.MapGatePipelineTest', str(smali)], check=True)
