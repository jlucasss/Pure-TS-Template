import express from 'express';
import 'dotenv/config';
const hostname = process.env.HOSTNAME;
const port = process.env.PORT;
function validateEnvVariable(variable, variableName) {
  if (variable === undefined) {
    console.error(`${variableName} is undefined.`);
    process.exit(1);
    // Sair do processo com código de erro 1 
  }
  return variable;
}
const validatedHostname = validateEnvVariable(hostname, "HOSTNAME");
const validatedPort = validateEnvVariable(port, "PORT");
if (isNaN(Number(validatedPort))) {
  console.error(`PORT is not a valid number: "${validatedPort}"`);
  process.exit(1);
  // Sair do processo com código de erro 1
}
const app = express();
app.get("/", (req, res) => {
  res.send("Hello World!");
});
app.listen(Number(validatedPort), validatedHostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});