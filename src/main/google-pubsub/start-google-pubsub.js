'use strict'

const cp = require('child_process')

async function startGooglePubSub ({ port, projects }) {
  projects = Array.from(new Set(projects))
  const env = projects.reduce((accum, project, index) => {
    accum[`PUBSUB_PROJECT${index + 1}`] = project
    return accum
  }, {})
  env.GOOGLE_PUBSUB_TEST_SUPPORT_PORT = port
  console.log(cp.execFileSync(`${__dirname}/start-google-pubsub.sh`, [], env).toString())
}

module.exports = startGooglePubSub
