// javascript

global.daily_path = function() {
  const [d] = new Date().toISOString().split("T");
  const [year, month, day] = d.split("-");
  // return `${year}/${month}-${day}.json`;
  return "2023/11/7"
} 

global.read_prefs = function() {
  try {
    return JSON.parse(localStorage.getItem("ltld.prefs") ?? {});
  } catch (err) {
    console.error(err);
  }
}

global.set_prefs = function(prefs) {
  try {
    localStorage.setItem("ltld.prefs", JSON.stringify(prefs));
  } catch (err) {
    console.error(err);
  }
}


global.read_params = function() {
  const params = new URLSearchParams(window.location.search);
  const result = {};
  for (const [key, value] of params) {
    result[key] = value;
  }
  return result;
}

