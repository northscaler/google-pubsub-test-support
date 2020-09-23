'use strict'

const fs = require('fs')
const waitOn = require('wait-on')
const { PubSub } = require('@google-cloud/pubsub')

const startGooglePubSub = require('./start-google-pubsub')

const defaultPort = parseInt(fs.readFileSync(`${__dirname}/default-google-pubsub-test-port`))
const defaultContainerName = fs.readFileSync(`${__dirname}/default-google-pubsub-test-container`).toString('utf8').trim()

const DEFAULT_PROJECT = 'test-support-project'
async function googlePubsubConnect ({
  port = defaultPort,
  projects = [DEFAULT_PROJECT]
} = {}) {
  const start = Date.now()

  if (!process.env.CI) {
    await startGooglePubSub({ port, projects })
    await waitOn({ resources: [`tcp:localhost:${port}`] })

    console.log(`started google-pubsub container in ${Date.now() - start} ms`)
  } else {
    console.log('skipped launching container')
  }

  process.env.PUBSUB_EMULATOR_HOST = process.env.PUBSUB_EMULATOR_HOST || `localhost:${port}`

  return projects.reduce((accum, projectId) => {
    accum[projectId] = new PubSub({ projectId })
    return accum
  }, {})
}

googlePubsubConnect.defaultPort = defaultPort
googlePubsubConnect.defaultContainerName = defaultContainerName
googlePubsubConnect.defaultProject = DEFAULT_PROJECT

module.exports = googlePubsubConnect
