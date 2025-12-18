@echo off
echo ============================================
echo SwatServe - Setup Script
echo ============================================
echo.

echo Step 1: Installing Flutter dependencies...
call flutter pub get
if errorlevel 1 goto error

echo.
echo Step 2: Checking Flutter setup...
call flutter doctor
if errorlevel 1 goto error

echo.
echo ============================================
echo Setup completed successfully!
echo ============================================
echo.
echo Next steps:
echo 1. Run: flutterfire configure
echo 2. Configure Firebase in Firebase Console
echo 3. Run: flutter run
echo.
echo See SETUP.md for detailed instructions
echo ============================================
goto end

:error
echo.
echo ============================================
echo ERROR: Setup failed!
echo Please check the error messages above
echo ============================================
pause
exit /b 1

:end
pause
