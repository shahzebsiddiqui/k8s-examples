from lmod.moduleloadtest import ModuleLoadTest
import sys
test = ModuleLoadTest(debug=True,login=True)
passed=test.get_results()['passed']
failed=test.get_results()['failed']
total=test.get_results()['total']
print("PASS: %d / %d" % (passed, total))
print("FAIL: %d / %d" % (failed, total))
print("RATE : %0.2f%%" % (100 * passed / total))
if failed > 0:
    print(f"Script exiting because there are {failed} modules that failed to load")
    sys.exit(1)


