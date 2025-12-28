import  express from 'express'
import type { Express, Request, Response } from 'express'
import 'dotenv/config'

const hostname: string|undefined = process.env.HOSTNAME;
const port: string|undefined = process.env.PORT;

function validateEnvVariable(variable: string | undefined, variableName: string): string {
  if (variable === undefined) {
    console.error(`${variableName} is undefined.`);
    process.exit(1); 
    // Sair do processo com código de erro 1 
  } return variable;
}

const validatedHostname: string = validateEnvVariable(hostname, "HOSTNAME");
const validatedPort       : string = validateEnvVariable(port, "PORT");

if (isNaN(Number(validatedPort))) {
  console.error(`PORT is not a valid number: "${validatedPort}"`);
  process.exit(1);
  // Sair do processo com código de erro 1
}

const app: Express = express()

app.get("/", (req: Request, res: Response) => {
  res.send("Hello World!")
})

app.listen(Number(validatedPort), validatedHostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
