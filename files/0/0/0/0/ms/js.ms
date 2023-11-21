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

global.add_html = function(html) {
  const template = document.createElement('template');
  template.innerHTML = html.trim();
  document.body.appendChild(template.content.firstChild);
  return template.content.firstChild;
}

global.listen_for_popup_events = function() {
  document.addEventListener('submit', function(event) {
    event.preventDefault();
    const name = event.target.name;
    document.body.removeAttribute("data-popup");
  }, true)
}

global.show_share = function(board, summary) {
  const emojiboard = board.map(row => {
    return row.map(cell => cell.selected ? "🟥" : "⬜️").join("")
  }).join("\n");
  
  const text = [
    `${summary.words} words, ${summary.points} points, ${summary.filled}% filled`,
    summary.daily,
    `Verdict: ${summary.heading}`,
    emojiboard
    ].join("\n");
  
  document.querySelector("#share_content").innerHTML = text;
  document.body.setAttribute("data-popup", "share"); 
}


global.go_to_url = function(url) {
  window.open(url, "_blank")
}

global.copy_summary = function(board, summary) {
  const emojiboard = board.map(row => {
    return row.map(cell => cell.selected ? "🟥" : "⬜️").join("")
  }).join("\n");
  
  const text = [
    `${summary.words} words, ${summary.points} points, ${summary.filled}% filled`,
    summary.daily,
    `Verdict: ${summary.heading}`,
    emojiboard
    ].join("\n");
  
  global.add_html(`<textarea id="copytext">${text}</textarea>`)
  const el = document.querySelector("#copytext");
  el.select();
  document.execCommand("copy");
  el.remove();
}



global.create_popups = function() {
  global.add_styles();
  
  const share = `
    <div class="popup" data-popup="share">
    <form name="share">
    <div class="content">
      <p>Copy and paste the below to share on the socials.</p>
    <textarea id="share_content"></textarea>
    </div>
    <footer>
      <button name="copy" type="submit">Copy</button>
      <button type="submit">Close</button>
    </footer>
    </form>
    </div>`;

  global.add_html(share);
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

body[data-popup=share] .popup[data-popup=share] {
  display: flex;
}

#copytext {
  width: 0;
  opacity: 0.1;
}

.popup {
  position: absolute;
  top: 0;
  left: 0;
  margin: 0;
  padding: 0;
  display: none;
  height: 100vh;
  width: 100%;
  justify-content: center;
  align-items: center;
  font-family: Helvetica Neue, Arial, sans-serif;
}

.popup form {
  background: rgb(255,255,255);
  max-width: 300px;
  height: auto;
  display: flex;
  flex-direction: column;  
  gap: 1rem;
  padding: 1rem;
  border-radius: 2.5%;
  box-shadow: 0px 0px 10px rgba(0,0,0,.4);
}


.popup footer {
  display: flex;
  justify-content: center;
}

.popup [type=submit] {
  display: flex;
  background: #0083c5;
  font-family: WilcoLoftSansTreble;
  font-size: 1.5rem;
  color: white;
  border-radius: 5%;
  border: none;
  padding: .5rem 1rem;
  box-shadow: 0px 3px black;
  min-width: 100px;
  justify-content: center;
  height: 2.5rem;
  
}

#share_content {
  width: 100%;
  height: 200px;
}
    </style>`;
  global.add_html(html);
}
