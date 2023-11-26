// javascript

global.dlog = function(...args) {
  console.log(...args)
}

global.track_event = function(name, props) {
  window.plausible?.(name, props);
}

global.is_safari = function() {
  return /Apple/.test(navigator.vendor) && /Safari/.test(navigator.userAgent)
}

global.daily_path = function() {
  const [d] = new Date().toISOString().split("T");
  const [year, month, day] = d.split("-");
  return `${year}/${month}/${day}`;
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

global.go_to_url = function(url) {
  window.open(url)
}

global.click_link = function(link) {
  document.querySelector("#"+link).click();
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
    
  if (navigator.share) {
    navigator.share({
      title: 'Let The Letter Drop',
      url: 'https://ltld.fun',
      text: text
    })
    .then(() => {
      global.track_event("Share", { via: "WebShareApi"})
    })
    .catch(console.error);
    return true;
  } else {
    global.add_html(`<textarea id="copytext">${text}</textarea>`)
    const el = document.querySelector("#copytext");
    el.select();
    document.execCommand("copy");
    el.remove();    
    global.track_event("Share", { via: "html"})
  }  
}

global.create_page_elements = function(urls) {
  global.add_html(`<a id="about" href="${urls.about}">About</a>`);
  global.add_html(`<a id="feedback" href="${urls.feedback}">Feedback</a>`);
}


