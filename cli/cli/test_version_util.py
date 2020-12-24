from unittest import TestCase
from version_util import compareVersion


class Test(TestCase):
    def test_compare_version(self):
        self.assertTrue(compareVersion('0.1', '0.2') == -1)
        self.assertTrue(compareVersion('0.2', '0.2') == 0)
        self.assertTrue(compareVersion('0.3', '0.2') == 1)
        self.assertTrue(compareVersion('0.1', '0.1.1') == -1)
        self.assertTrue(compareVersion('0.1.1', '0.2') == -1)
        self.assertTrue(compareVersion('0.2.0.0.0.0.0.0.1', '0.2') == 1)
