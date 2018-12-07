import { Controller } from "stimulus"
import { Howl } from "howler"
import moment from "moment"
import momentDurationFormatSetup from "moment-duration-format"

momentDurationFormatSetup(moment)

/**
 * Controls playback of uploaded tracks
 */
export default class Player extends Controller {
  static targets = ["button", "elapsed", "like", "listens", "notch"]

  initialize() {
    this.updateElapsedTime = this.updateElapsedTime.bind(this)
    this.updateProgress = this.updateProgress.bind(this)
  }

  /**
   * Create the sound with Howl
   */
  connect() {
    const href = this.buttonTarget.getAttribute("href")
    const src = [href]
    const onplay = this.start.bind(this)
    const onpause = this.stop.bind(this)

    this.sound = new Howl({ src, onplay, onpause })
    this.playing = false
    this.secondsElapsed = 0
    this.listens = parseInt(this.element.getAttribute("data-listens"))
    this.totalDuration = parseInt(this.element.getAttribute("data-duration"))
    this.liked = this.element.getAttribute("data-liked")
    this.ticks = 0
    this.totalTicks = this.totalDuration * 1000
  }

  /**
   * Clean up existing Howl sounds from the environment when
   * disconnected from the DOM
   */
  disconnect() {
    this.sound.unload()
  }

  /**
   * Update the elapsed time on the player
   */
  updateElapsedTime() {
    this.secondsElapsed++

    let elapsedTime = moment.duration(this.secondsElapsed, "seconds")
                            .format("mm:ss")

    if (elapsedTime.length == 2) {
      elapsedTime = `00:${elapsedTime}`
    }

    // const percent = (this.secondsElapsed / this.totalDuration) * 100

    this.elapsedTarget.innerText = elapsedTime
    // this.notchTarget.style.left = `${percent}%`
  }

  updateProgress() {
    this.ticks++

    const percent = (this.ticks / this.totalTicks) * 100

    this.notchTarget.style.left = `${percent}%`
  }

  get url() {
    return this.element.getAttribute("data-track")
  }

  /**
   * Toggle play/pause functionality on the sound
   */
  toggle(event) {
    event.preventDefault()

    if (this.playing) {
      this.pause()
    } else {
      this.play()
      this.listened()
    }
  }

  /**
   * Like or unlike the track
   */
  async like(event) {
    event.preventDefault()

    const url = `${this.url}/like.json`
    const method = this.liked ? "DELETE" : "POST"
    const response = await fetch(url, { method })

    if (response.status === 200) {
      const { likes } = await response.json()
      this.liked = method === "POST"

      this.likesTarget.innerText = `${likes} likes`
    }
  }


  /**
   * Pause the currently-playing track
   */
  pause() {
    this.sound.pause()
    this.playing = false

    this.buttonTarget.classList.remove("player__icon--playing")
    this.buttonTarget.classList.add("player__icon--paused")
  }

  /**
   * Play the track defined by this player
   */
  play() {
    this.sound.play()
    this.playing = true

    this.buttonTarget.classList.remove("player__icon--paused")
    this.buttonTarget.classList.add("player__icon--playing")
  }

  start() {
    this.elapsedTimeInterval = setInterval(this.updateElapsedTime, 1000)
    this.progressInterval = setInterval(this.updateProgress, 1)
  }

  stop() {
    clearInterval(this.elapsedTimeInterval)
    clearInterval(this.progressInterval)
  }

  /**
   * Track playback by a given client.
   */
  async listened() {
    const csrfToken = document.querySelector("meta[name=\"csrf-token\"]")
                              .getAttribute("content")
    const method = "POST"
    const url = `${this.url}/listen.json`
    const headers = { "X-CSRF-Token": csrfToken }
    const response = await fetch(url, { method, headers })

    if (response.status === 201) {
      const { listens } = await response.json()

      this.listensTarget.innerText = `${listens} listens`
    }
  }
}
