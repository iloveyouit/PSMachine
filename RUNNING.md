# PSMachine - Currently Running

## ✅ Application Status: RUNNING

Both the backend and frontend are currently running in virtual environments!

### 🔗 Access URLs

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:5001
- **API Health Check**: http://localhost:5001/api/health

### 🔐 Default Login Credentials

```
Username: admin
Password: admin
```

**IMPORTANT**: Change this password immediately after logging in!

### 📊 System Information

**Backend:**
- Flask server running in Python virtual environment
- Database: SQLite (`psmachine.db`)
- Port: 5001
- Location: `/backend/`
- Process ID: Check with `ps aux | grep python | grep app.py`

**Frontend:**
- Vite development server
- React 18.2.0 with TypeScript
- Port: 5173
- Location: `/frontend/`
- Hot reload enabled

### 🛠️ Managing the Application

#### View Logs

Backend logs are shown in the terminal where it's running, or:
```bash
# Check backend output
# Process is running in background

# Frontend is also running in background
```

#### Stop Services

To stop the servers:
```bash
# Find and kill Python backend process
ps aux | grep "python app.py" | grep -v grep | awk '{print $2}' | xargs kill

# Find and kill npm/vite frontend process
ps aux | grep "vite" | grep -v grep | awk '{print $2}' | xargs kill
```

Or simply close the terminal windows where they're running.

#### Restart Services

**Backend:**
```bash
cd backend
source venv/bin/activate
python app.py
```

**Frontend:**
```bash
cd frontend
npm run dev
```

### 📝 Quick Test

1. **Test Backend API:**
   ```bash
   curl http://localhost:5001/api/health
   # Should return: {"database": "connected", "status": "healthy"}
   ```

2. **Test Frontend:**
   - Open browser to http://localhost:5173
   - You should see the PSMachine login page

3. **Test Login:**
   - Login with `admin` / `admin`
   - Should redirect to dashboard

### 🎯 Next Steps

1. **Login** at http://localhost:5173
2. **Create a test script:**
   - Click "New Script"
   - Name: "Hello World"
   - Category: "Utilities"
   - Content:
     ```powershell
     Write-Host "Hello from PSMachine!" -ForegroundColor Green
     Write-Host "Current date: $(Get-Date)"
     Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
     ```
   - Click "Save"

3. **Execute the script:**
   - Click "Execute" on your new script
   - Watch the real-time output!

4. **View execution history:**
   - Click "Execution History" in sidebar
   - See your script run with full details

### 🔧 Development Commands

**Backend (in backend/ directory):**
```bash
# Activate virtual environment
source venv/bin/activate

# Install new dependencies
pip install package-name
pip freeze > requirements.txt

# Database migrations (if needed)
# Currently using auto-create on startup

# Deactivate virtual environment
deactivate
```

**Frontend (in frontend/ directory):**
```bash
# Install new dependencies
npm install package-name

# Build for production
npm run build

# Type checking
npm run lint

# Preview production build
npm run preview
```

### 📁 Important Files

**Backend:**
- `backend/psmachine.db` - SQLite database
- `backend/.env` - Environment configuration
- `backend/app.py` - Main application
- `backend/models.py` - Database models

**Frontend:**
- `frontend/src/` - React source code
- `frontend/dist/` - Production build output (after `npm run build`)

### 🐛 Troubleshooting

**Backend won't start:**
- Check Python version: `python3 --version` (need 3.11+)
- Check virtual environment: `source venv/bin/activate`
- Check dependencies: `pip install -r requirements.txt`
- Check port 5001 is free: `lsof -i :5001`

**Frontend won't start:**
- Check Node version: `node --version` (need 16+)
- Delete node_modules and reinstall: `rm -rf node_modules && npm install`
- Check port 5173 is free: `lsof -i :5173`

**PowerShell scripts won't execute:**
- Verify PowerShell Core is installed: `pwsh --version`
- Install PowerShell Core:
  ```bash
  # macOS
  brew install powershell

  # Linux
  # See: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
  ```

**Database errors:**
- Delete database and restart: `rm backend/psmachine.db`
- Backend will recreate on next startup

### 💾 Database Location

The SQLite database is stored at:
```
backend/psmachine.db
```

To backup:
```bash
cp backend/psmachine.db backend/psmachine.db.backup
```

To reset (WARNING: Deletes all data):
```bash
rm backend/psmachine.db
# Restart backend to recreate with default admin user
```

### 🎉 Features to Try

1. **Script Management**
   - Create, edit, delete scripts
   - Organize by category (VMware, Azure, AD, etc.)
   - Add tags for searching
   - Mark scripts as public/private

2. **Script Execution**
   - One-click execution
   - Define parameters
   - View real-time output
   - Check exit codes

3. **History & Auditing**
   - View all past executions
   - See full output logs
   - Check execution duration
   - Delete old records

4. **Security**
   - Role-based access (admin/user)
   - Restricted cmdlets for safety
   - Admin bypass for unrestricted access

### 📚 Documentation

- **README.md** - Complete documentation
- **QUICKSTART.md** - 5-minute getting started guide
- **PROJECT_SUMMARY.md** - Technical architecture
- **starter.md** - Original requirements

---

**Started**: October 31, 2025
**Environment**: Local development (virtual environments)
**Status**: ✅ Running and ready for testing!
