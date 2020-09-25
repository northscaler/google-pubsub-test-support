/* global describe, it */
'use strict'

const Promise = require('bluebird')
const uuid = require('uuid').v4
const chai = require('chai')
chai.use(require('dirty-chai'))
const expect = chai.expect

const googlePubSubConnect = require('../../../main')

describe('integration tests of google-pubsub', function () {
  describe('google-pubsub-connect', function () {
    it('should work', async function () {
      // eslint-disable-next-line no-async-promise-executor
      return new Promise(async (resolve, reject) => {
        if (process.env.CI) { // don't run this in CI pipeline
          console.log('skipping because in CI pipeline')
          return resolve()
        }
        this.timeout(60000)

        let subscription
        let topic

        const cleanup = async () => {
          try {
            if (topic) await topic.delete()
          } catch (e) {
            console.warn(`failed to delete topic ${topic.name}`)
          }

          try {
            if (subscription) await subscription.delete()
          } catch (e) {
            console.warn(`failed to delete subscription ${subscription.name}`)
          }
        }

        try {
          const pubsubs = await googlePubSubConnect()
          const project = googlePubSubConnect.defaultProject
          const pubsub = pubsubs[project]
          expect(pubsub).to.be.ok()

          topic = (await pubsub.createTopic(`x${uuid()}`))[0]
          const data = { id: uuid() }
          const buffer = Buffer.from(JSON.stringify(data))

          subscription = (await pubsub.createSubscription(topic, `x${uuid()}`))[0]
          const handleMessage = async msg => {
            try {
              msg.ack()

              const msgData = JSON.parse(Buffer.from(msg.data, 'base64').toString('utf8'))
              expect(msgData).to.deep.equal(data)

              resolve()
            } catch (e) {
              reject(e)
            } finally {
              await cleanup()
            }
          }

          subscription.on('message', handleMessage)

          const id = await topic.publish(buffer)
          expect(id).to.be.ok()
        } catch (e) {
          return (await cleanup()) || reject(e)
        }
      })
    })
  })
})
