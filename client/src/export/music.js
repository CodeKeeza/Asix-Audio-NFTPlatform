let fs = require('fs')
let axios = require('axios')

let media = ['edmTrack1.mp3', 'edmTrack2.mp3', 'edmTrack3.mp3', 'djimg.jpg']
let ipfsArray = []
let promises = []

for (let i = 0; i < media.length; i++) {
  promises.push(
    new Promise((res, rej) => {
      fs.readFile(`${__dirname}/export/tunes/${media[i]}`, (err, data) => {
        if (err) rej()
        console.log(data)

        ipfsArray.push({
          path: `media/${i}`,
          content: data.toString('base64'),
        })
        res()
      })
    }),
  )
}

Promise.all(promises).then(() => {
  axios
    .post('https://deep-index.moralis.io/api/v2/ipfs/uploadFolder', ipfsArray, {
      headers: {
        'X-API-KEY':
          'tXNk2KzwewVnTvqz5EsTKPllSRTlAKl3Zqe8UD66yz309DyE9JB3DcFhT71KnFqy',
        'Content-Type': 'application/json',
        accept: 'application/json',
      },
    })
    .then((res) => {
      console.log(res.data)
    })
    .catch((error) => {
      console.log(error)
    })
})
