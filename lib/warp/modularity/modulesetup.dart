abstract class ModuleSetup {
  String moduleName();

  void registerExports() {}
  void resolveImports() {}

  Future<void> onInit() async {}
}
