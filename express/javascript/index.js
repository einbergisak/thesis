const express = require("express");
const app = express();
const port = 8080;

app.get("/", (req, res) => {
  res.send("Hello world!");
});

app.get("/lipsum.txt", (req, res) => {
  res.sendFile("/tmp/lipsum.txt", (err) => {
    if (err) {
      console.error(err);
      res.status(500).send("Error sending file");
    }
  });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
