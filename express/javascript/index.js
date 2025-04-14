const express = require("express");
const { Pool } = require("pg");
const app = express();
const port = 8080;

// Configure PostgreSQL connection
const connection = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "password",
  port: 5432,
});

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

app.get("/postgres", (req, res) => {
  connection.query("SELECT * FROM tableone", (err, result) => {
    if (err) {
      res.status(500).send(err);
    } else {
      res.json(result.rows);
    }
  });
});

app.get("/fibonacci", (req, res) => {
  const fib = (n) => {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
  };
  res.json(fib(40));
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
