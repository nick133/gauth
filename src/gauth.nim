
import
  os,
  tables,
  rdstdin,
  strformat,
  strutils,
  system,
  osproc,
  parsecfg,
  parseopt,
  otp

const version = "0.2.0"

type Options = object
  config, provider : string
  pause : bool

var
  opts : Options
  conf : Config


proc guessProvider(provider : string) : string =
  let provarglc = provider.toLowerAscii

  for prov in conf["providers"].keys:
    let provkeylc = prov.toLowerAscii

    if provkeylc == provarglc or
      (provkeylc.len > provarglc.len and provarglc == provkeylc.substr(0, provarglc.len-1)):
      return prov


proc genTOTP(provider : string) : string =
  let
    code = newTotp(conf.getSectionValue("providers", provider)).now.intToStr.align(6, '0') # i.e. 7653 -> 007653
    cmd = conf.getSectionValue("config", "exec").replace("%code%", code)

  if execCmd(cmd) != 0:
    echo &"Failed execution of command line: {cmd}"

  result = code


# main():
for kind, key, val in getopt(
  shortNoVal = {'h', 'p'}, longNoVal = @["help", "pause"]):
  case kind
  of cmdArgument:
    opts.provider = key
  of cmdLongOption, cmdShortOption:
    case key
      of "help", "h":
        echo &"Google TOTP Authentificator v{version}\n"
        echo "Usage: gauth [-h|--help] [-p|--pause] [(-c|--conf[ig]) config.ini] [provider]"
        quit(QuitSuccess)
      of "pause", "p": opts.pause = true
      of "conf", "config", "c": opts.config = val
  of cmdEnd: assert(false)

if opts.config.len == 0:
  for dir in [getCurrentDir() & "/", getConfigDir()]:
    let fn = dir & "gauth.ini"
    if fileExists fn:
      opts.config = fn
      break

if opts.config.len == 0:
  quit"Error: config file is missing!"

conf = loadConfig opts.config

# Non-interactive
if opts.provider.len > 0:
  let provider = guessProvider(opts.provider)

  if provider.len > 0:
    echo provider.genTOTP
  else:
    quit &"Invalid TOTP provider: {opts.provider}"

# Interactive
else:
  var
    code : string
    provIds : seq[string]
    prov_id = 0

  echo "Generate Google Authentification TOTP code\n"

  for prov,_ in conf["providers"]:
    prov_id.inc
    provIds.add(prov)
    echo &" {prov_id} : {prov}"

  prov_id = 0
  while prov_id == 0 or prov_id > provIds.len-1:
    prov_id = (try: parseInt(readLineFromStdin("\nSelect provider [1]: ")) except: 1)

  code = provIds[prov_id-1].genTOTP

  echo &"Generated TOTP code for {provIds[prov_id-1]}: {code}"

  if opts.pause or conf.getSectionValue("config", "pause") == "yes":
    discard readLineFromStdin("Press <Enter> to quit")

