// javascript

global.daily_path = function() {
  const [d] = new Date().toISOString().split("T");
  const [year, month, day] = d.split("-");
  return `${year}/${month}-${day}.json`;
} 