from spinny import newSpinny, setSymbolColor, start, error, success, stop, setText, SpinnerKind,
    fgLightGreen, fgGreen

let spinner = newSpinny("Loading..".fgLightGreen, SpinnerKind.Flip)
spinner.setSymbolColor(fgGreen)

proc spinnerStart*(): void =
  spinner.start()

proc spinnerSuccess*(str: string): void =
  spinner.success(str)

proc spinnerError*(str: string): void =
  spinner.error(str)

proc spinnerStop*(): void =
  spinner.stop()

proc spinnerText*(str: string): void =
  spinner.setText(str)
