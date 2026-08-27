{
  lib,
  flake,
  python314,
  fetchFromGitHub,
  fetchPypi,
  versionCheckHook,
  versionCheckHomeHook,
}:

let
  # nixpkgs still marks 0.2.1 unfree from before upstream added its MIT license.
  textual-speedups = python314.pkgs.textual-speedups.overridePythonAttrs (oldAttrs: {
    meta = oldAttrs.meta // {
      license = lib.licenses.mit;
    };
  });

  format-currency = python314.pkgs.buildPythonPackage rec {
    pname = "format-currency";
    version = "0.0.10";
    pyproject = true;

    src = fetchPypi {
      pname = "format_currency";
      inherit version;
      hash = "sha256-FfAeWq7PfGNoFZEc8MurCxF8imvZktYaZm9eA4zOMtk=";
    };

    build-system = with python314.pkgs; [ hatchling ];

    pythonImportsCheck = [ "format_currency" ];
  };

  textual-diff-view = python314.pkgs.buildPythonPackage rec {
    pname = "textual-diff-view";
    version = "0.1.5";
    pyproject = true;

    src = fetchPypi {
      pname = "textual_diff_view";
      inherit version;
      hash = "sha256-4oFRxF1CB/t7ULV/zivCSeiAwqSWshv32FYKkuWcrss=";
    };

    build-system = with python314.pkgs; [ uv-build ];
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'uv_build>=0.9.18,<0.10.0' 'uv_build>=0.9.18'
    '';
    dependencies = with python314.pkgs; [ textual ];

    pythonImportsCheck = [ "textual_diff_view" ];
  };
in
python314.pkgs.buildPythonApplication rec {
  pname = "toad";
  version = "0.6.20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "batrachianai";
    repo = "toad";
    tag = "v${version}";
    hash = "sha256-nsmfXjXqnOU8b+hkURg1b11D0lc1clA99tR0QkbYv78=";
  };
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'hatchling==1.28.0' 'hatchling>=1.28.0'
  '';

  build-system = with python314.pkgs; [ hatchling ];

  dependencies = with python314.pkgs; [
    aiosqlite
    bashlex
    click
    format-currency
    httpx
    notify-py
    packaging
    pathspec
    platformdirs
    psutil
    pyperclip
    rich
    setproctitle
    textual
    textual-diff-view
    textual-serve
    textual-speedups
    typeguard
    typing-extensions
    watchdog
    xdg-base-dirs
  ];

  pythonRelaxDeps = [
    "aiosqlite"
    "click"
    "platformdirs"
    "textual"
    "typing-extensions"
  ];

  pythonImportsCheck = [ "toad" ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "Terminal UI for working with AI coding agents";
    homepage = "https://github.com/batrachianai/toad";
    changelog = "https://github.com/batrachianai/toad/releases/tag/v${version}";
    license = licenses.agpl3Plus;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with flake.lib.maintainers; [ vidhanio ];
    mainProgram = "toad";
    platforms = platforms.unix;
  };
}
