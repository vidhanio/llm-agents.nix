{
  lib,
  flake,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_10,
  pnpmConfigHook,
  versionCheckHook,
  versionCheckHomeHook,
}:

buildNpmPackage rec {
  pname = "acpx";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "openclaw";
    repo = "acpx";
    tag = "v${version}";
    hash = "sha256-00MJjk0uQKs8Cz7NXf7YDWS3yCj9qWweNot55VESifw=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-dFcd7ccHhhjfZOAfH8Jg1HOr4qrtdvOcbQH2RCTHqBY=";
  };

  nativeBuildInputs = [ pnpm_10 ];
  npmConfigHook = pnpmConfigHook;

  # npm prune hangs on pnpm-managed node_modules.
  dontNpmPrune = true;

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];

  passthru.category = "ACP Ecosystem";

  meta = with lib; {
    description = "Headless CLI client for the Agent Client Protocol";
    homepage = "https://github.com/openclaw/acpx";
    changelog = "https://github.com/openclaw/acpx/releases/tag/v${version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with flake.lib.maintainers; [ vidhanio ];
    mainProgram = "acpx";
    platforms = platforms.all;
  };
}
