package main

import (
	"fmt"
	"os/exec"
	"path/filepath"
)

// this file is used as playground

func main() {
	fmt.Println("Play with MATLAB !")
	lookUp()
	execScript("E:\\workspace\\src\\github.com\\at15\\mk-fld\\src\\solver\\fld_solver_main.m")
}

func lookUp() {
	p, err := exec.LookPath("matlab")
	if err != nil {
		fmt.Println(err)
	} else {
		// C:\Program Files\MATLAB\R2016a\bin\matlab.exe
		fmt.Println(p)
	}
}

func execScript(mFile string) {
	// "C:\Program Files\MATLAB\R2016a\bin\matlab.exe" -nosplash -nodesktop -nojvm -noFigureWindows -minimize -r "cd('E:\workspace\src\github.com\at15\mk-fld\src\solver'); inputFile='c.fldin';run('E:\workspace\src\github.com\at15\mk-fld\src\solver\fld_solver_main.m');exit;"
	mFile, _ = filepath.Abs(mFile)
	dir := filepath.Dir(mFile)
	script := fmt.Sprintf("cd('%s');run('%s');exit;", dir, mFile)
	fmt.Println(script)

	cmd := exec.Command("matlab", "-nosplash", "-nodesktop", "-nojvm", "-noFigureWindows", "-minimize",
		"-r", script)
	err := cmd.Run()
	fmt.Println(err)
	// NOTE: err is always nil, go does not wait until the script finish execution
}
