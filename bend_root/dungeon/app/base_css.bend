def base_css() -> String:
  ""
  ++ ":root{--bg:#ffffff;--surface:#f2f2f2;--surface-strong:#e3e3e3;--surface-border:#d2d2d2;--text:#111111;--text-muted:#555555;--accent:#202020;--danger:#c21c1c;--shadow:0 16px 40px rgba(17,17,17,0.08);--radius-lg:28px;--radius-md:20px;--radius-sm:14px;}"
  ++ "*{box-sizing:border-box;}html,body{margin:0;height:100%;min-height:100%;background:var(--bg);color:var(--text);font-family:'Avenir Next','Trebuchet MS',sans-serif;overflow-x:hidden;}body{overflow:hidden;overscroll-behavior:none;}button,input,select{font:inherit;}button{cursor:pointer;}a{color:inherit;}img{display:block;max-width:100%;}#app,.page{min-height:100svh;}"
