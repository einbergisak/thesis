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

// Use JSON parsing middleware
app.use(express.json());

app.post("/json", (req, res) => {
  try {
    // Receive and parse JSON
    const data = req.body;

    // Check that there is data, as an empty body is parsed as an empty object
    if (!data || Object.keys(data).length === 0) {
      throw new Error();
    }

    // Serialize and respond
    res.json(data);
  } catch (error) {
    res.status(400).send("Invalid request");
  }
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
