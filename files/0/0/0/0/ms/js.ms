// javascript

global.dlog = function(...args) {
  console.log(...args)
}

global.is_safari = function() {
  return /Apple/.test(navigator.vendor) && /Safari/.test(navigator.userAgent)
}

global.daily_path = function() {
  const [d] = new Date().toISOString().split("T");
  const [year, month, day] = d.split("-");
  // return `${year}/${month}-${day}.json`;
  return "2023/11/7"
} 

global.read_params = function() {
  const params = new URLSearchParams(window.location.search);
  const result = {};
  for (const [key, value] of params) {
    result[key] = value;
  }
  return result;
}

global.show_howto = function() {
  document.body.setAttribute('data-popup', 'howto');
}

global.show_mode = function() {
  document.body.setAttribute('data-popup', 'mode');
}

global.add_html = function(html) {
  const template = document.createElement('template');
  template.innerHTML = html.trim();
  document.body.appendChild(template.content.firstChild)  
}

global.listen_for_popup_events = function() {
  document.addEventListener('submit', function(event) {
    event.preventDefault();
    const name = event.target.name;
    if (name === 'howto') {
      document.body.setAttribute("data-popup", "mode");
    }
    
    if (name === 'mode') {
      const mode = event.submitter.getAttribute('data-type');
      document.body.removeAttribute("data-popup");
      if (mode === '1') {
        window.player.call("reset_game",["1"]);
      } else {
        window.player.call("reset_game",["0"]);
      }
      
    }  
  }, true)
}


global.create_popups = function() {
  global.add_styles();
  
  const howto = `
    <div class="popup" data-popup="howto">
    <form name="howto">
    <div class="content">
      <h2><span style="font-size: 5rem;">LTLD</span><span style="font-size: 2rem;">Let The Letter Drop</span></h2>      
      <p class="summary">
      Drop letters on the board to make 4- and 5-letter words. Use 💣 and ⬅️➡️ blocks to remove or move dropped letters. Play for points or just fill up the board.
      </p>
      <h3>Controls</h3>
      <ul>
      <li><em>Desktop</em> Use arrow keys or WASD to move and rotate pieces, Space or Enter to select and drop them. 
      <li><em>Mobile</em> Use the on-screen controls. 🔘 Gray button rotates, 🔴 red selects. </li>
      </ul>
    </div>
    <footer>
      <button type="submit">Got it</button>
    </footer>
    </form>
    </div>`;
    
  const mode = `
    <div class="popup" data-popup="mode">
    <form name="mode">
    <div class="content">
      <h2>What's your style?</h2>      
      <ul>
      <li><em>Daily Challenge</em>  
        Each day, everyone gets the same letters (but randomized) and a set of bonus words. You still want to make as many words as you can, but the bonus words are worth 100 points each.
      </li>
      <li><em>Freeplay</em> 
        Get a random set of letters each time you play. Play for points or completeness or maybe just pass the time?
      </li>
      </ul>
    </div>
    <footer>
      <button type="submit" data-type="0">Daily</button>
      <button type="submit" data-type="1">Freeplay</button>
    </footer>
    </form>
    </div>`    
  
  global.add_html(howto);
  global.add_html(mode);
}


global.add_styles = function() {
  const html = `
    <style>
@font-face { 
  font-family: "wilcoloftsanstreble"; 
  src: url("assets/wilcoloftsanstreble.ttf") format("truetype"); 
}    

body {
  background: #313030;
}

body[data-popup=howto] .popup[data-popup=howto],
body[data-popup=mode] .popup[data-popup=mode] {
  display: flex;
}

.popup {
  position: absolute;
  top: 0;
  left: 0;
  background: rgba(45, 45, 45, 0.96);
  margin: 0;
  padding: 0;
  display: none;
  height: 100vh;
  width: 100%;
  justify-content: center;
  font-family: Helvetica Neue, Arial, sans-serif;
}

.popup form {
  background: rgb(255,255,255);
  max-width: 500px;
}


.popup h2, .popup h3 {
  font-family: WilcoLoftSansTreble;
  display: flex;
  justify-content: center;
  font-size: 3.25rem;
  margin: 0;
  padding: 0;
  text-align: center;
  flex-direction: column;
}

.popup h2 {  padding: 1rem; color: red;text-shadow: 0px 3px black;}
.popup h3 { font-size: 2rem; }
.popup form {
  padding: 2rem;
border: 1px solid #ddd;
}

.popup .summary {
  font-weight: bold;
  font-size: 1.1rem;
}
.popup footer {
  display: flex;
  justify-content: center;
  gap: 2rem;
}

.popup em {
  display: block;
  font-weight: bold;
  font-family: WilcoLoftSansTreble;
  font-size: 1.5rem;
  font-style: normal;
  text-align: center;
}

.popup ul {
  display: flex;
  flex-direction: row;
  align-items: start;
  gap: 1rem;
  margin: 1rem 0;
  padding: 0;
}

.popup li {
  list-style: none;
  margin-bottom: 1rem;
  width: 80%;
}

.popup [type=submit] {
  display: flex;
  background: red;
  font-family: WilcoLoftSansTreble;
  font-size: 1.5rem;
  color: white;
  border-radius: 5px;
  border: none;
  padding: 10px 20px;
  box-shadow: 0px 3px black;
  
}

.popup .gray, .popup .red {
  display: inline-flex;
  background: #999;
  color: white;  
  border-radius: 5px;
  padding: 3px 5px;
  box-shadow: 0px 2px black;
}

.popup .red {
  background: red;  
}
    </style>`;
  global.add_html(html);
}
