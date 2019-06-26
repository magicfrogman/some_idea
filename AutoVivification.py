class AutoVivification(dict):
    """Implementation of perl's autovivification feature.
    一个任意深度迭代的类，大大简化了建树过程，666
    """
    def __getitem__(self, item):
        try:
            return dict.__getitem__(self, item)
        except KeyError:
            value = self[item] = type(self)()
            return value