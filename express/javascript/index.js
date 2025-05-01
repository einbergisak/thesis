const express = require("express");
const cluster = require("node:cluster");
const numCPUs = require("node:os").availableParallelism();
const { Sequelize, DataTypes } = require("sequelize");
const app = express();
const port = 8080;

if (cluster.isPrimary) {
  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
} else {
  // Configure PostgreSQL connection
  const sequelize = new Sequelize({
    dialect: "postgres",
    host: "db",
    port: 5432,
    database: "postgres",
    username: "postgres",
    password: "password",
  });

  const Film = sequelize.define(
    "film",
    {
      film_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
      },
      title: {
        type: DataTypes.STRING,
      },
      description: {
        type: DataTypes.STRING,
      },
    },
    {
      freezeTableName: true,
    }
  );

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
      // Receive JSON
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

  app.get("/postgres", async (req, res) => {
    try {
      const randomId = Math.floor(Math.random() * 1000) + 1;

      const randomFilm = await Film.findOne({
        where: {
          film_id: randomId,
        },
        attributes: ["film_id", "title", "description"],
      });

      if (randomFilm) {
        res.json(randomFilm);
      } else {
        res.status(400).send("No film found");
      }
    } catch (error) {
      res.status(500).send("Invalid request");
    }
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
}
