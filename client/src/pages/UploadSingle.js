import React, { useState } from 'react'
import cn from 'classnames'
import styles from './UploadDetails.module.sass'
import Dropdown from '../components/Dropdown'
import Icon from '../components/Icon'
import TextInput from '../components/TextInput'
import Switch from '../components/Switch'
import Loader from '../components/Loader'
import Modal from '../components/Modal'
import Preview from '../components/UploadSingle/Preview'
import Cards from '../components/UploadSingle/Cards'
import FolowSteps from '../components/UploadSingle/FolowSteps'
import {
  useMoralis,
  useMoralisFile,
  useWeb3ExecuteFunction,
} from 'react-moralis'
import { nftAddress } from '../../config.js'
import nftContract from '../../nft.json'

const royaltiesOptions = ['10%', '20%', '30%']

const items = [
  {
    title: 'Create collection',
    color: '#4BC9F0',
  },
  {
    title: 'Crypto Legend - Professor',
    color: '#45B26B',
  },
  {
    title: 'Crypto Legend - Professor',
    color: '#EF466F',
  },
  {
    title: 'Legend Photography',
    color: '#9757D7',
  },
]

const UploadSingle = () => {
  const [royalties, setRoyalties] = useState(royaltiesOptions[0])
  const [sale, setSale] = useState(true)
  const [price, setPrice] = useState(false)
  const [locking, setLocking] = useState(false)
  const [itemName, setItemName] = useState()
  const [description, setDescription] = useState()
  const [userFile, setUserFile] = useState(null)
  const [url, setUrl] = useState('')
  const [hash, saveHash] = useState()

  const [visibleModal, setVisibleModal] = useState(false)
  const [visiblePreview, setVisiblePreview] = useState(false)

  const { user, Moralis, Web3 } = useMoralis()
  const { isUploading, moralisFile, saveFile } = useMoralisFile()

  const { data, error, fetch, isFetching, isLoading } = useWeb3ExecuteFunction()

  const handleItemName = (e) => {
    const input = e.target.value
    setItemName(input)
  }
  const handleDesc = (e) => {
    const input = e.target.value
    setDescription(input)
  }
  const handleFile = async (e) => {
    const file = e.target.files[0]
    var reader = new FileReader()
    var url = reader.readAsDataURL(file)

    reader.onloadend = (e) => {
      setUserFile(reader.result)
    }
    saveFile(itemName, file, { saveIPFS: true })
    const hash = moralisFile._hash
    saveHash(hash)
    console.log(hash)
  }

  const options = {
    contractAddress: nftAddress,
    functionName: 'customerMint',
    abi: nftContract,
    msgValue: Moralis.Units.ETH('0.030'),
    params: {
      uri: hash,
    },
  }

  const devUri1 = 'QmPeBiCxV231zBfvajpaqzaVASJR5Uy7ir5D1feXnH2soX'
  const devOptions1 = {
    contractAddress: nftAddress,
    functionName: 'customerMint',
    abi: nftContract,
    msgValue: Moralis.Units.ETH('0.030'),
    params: {
      uri: devUri1,
    },
  }
  const devUri2 = 'QmPEZgtvFhFmfWorCQxTQxESWV7k7zU6sy6W54rY4v6PiU'
  const devOptions2 = {
    contractAddress: nftAddress,
    functionName: 'customerMint',
    abi: nftContract,
    msgValue: Moralis.Units.ETH('0.030'),
    params: {
      uri: devUri2,
    },
  }
  const devUri3 = 'QmTW4dUJpbJKn4risAn5bm9xq5W3dMB5VRV7AwtaAir4ah'
  const devOptions3 = {
    contractAddress: nftAddress,
    functionName: 'customerMint',
    abi: nftContract,
    msgValue: Moralis.Units.ETH('0.030'),
    params: {
      uri: devUri3,
    },
  }
  const devUri4 = 'QmP4sj9YsuTtR2JUHPauiWsNjoKBxeZM4bGVkb316Jt3jB'
  const devOptions4 = {
    contractAddress: nftAddress,
    functionName: 'customerMint',
    abi: nftContract,
    msgValue: Moralis.Units.ETH('0.030'),
    params: {
      uri: devUri4,
    },
  }

  async function onMint() {
    const contractAddress = nftAddress
    const contractAbi = nftContract
    const mint = await Moralis.executeFunction(options)
  }

  async function onDevMint() {
    const contractAddress = nftAddress
    const contractAbi = nftContract
    const mint = await Moralis.executeFunction(devOptions1)
  }
  async function onDevMint2() {
    const contractAddress = nftAddress
    const contractAbi = nftContract
    const mint = await Moralis.executeFunction(devOptions2)
  }
  async function onDevMint3() {
    const contractAddress = nftAddress
    const contractAbi = nftContract
    const mint = await Moralis.executeFunction(devOptions3)
  }
  async function onDevMint4() {
    const contractAddress = nftAddress
    const contractAbi = nftContract
    const mint = await Moralis.executeFunction(devOptions4)
  }

  return (
    <>
      <div className={cn('section', styles.section)}>
        <div className={cn('container', styles.container)}>
          <div className={styles.wrapper}>
            <div className={styles.head}>
              <div className={cn('h2', styles.title)}>
                Create single collectible
              </div>
              <button
                onClick={onDevMint}
                className={cn('button-stroke button-small', styles.button)}
              >
                DevMint1
              </button>
              <button
                onClick={onDevMint2}
                className={cn('button-stroke button-small', styles.button)}
              >
                DevMint2
              </button>
              <button
                onClick={onDevMint3}
                className={cn('button-stroke button-small', styles.button)}
              >
                DevMint3
              </button>
              <button
                onClick={onDevMint4}
                className={cn('button-stroke button-small', styles.button)}
              >
                DevMint4
              </button>
            </div>
            <form className={styles.form} action="">
              <div className={styles.list}>
                <div className={styles.item}>
                  <div className={styles.category}>Upload file</div>
                  <div className={styles.note}>
                    Drag or choose your file to upload
                  </div>
                  <div className={styles.file}>
                    <input
                      className={styles.load}
                      type="file"
                      onChange={handleFile}
                    />
                    <div className={styles.icon}>
                      <Icon name="upload-file" size="24" />
                    </div>
                    <div className={styles.format}>
                      PNG, GIF, WEBP, MP4 or MP3. Max 1Gb.
                    </div>
                  </div>
                </div>
                <div className={styles.item}>
                  <div className={styles.category}>Item Details</div>
                  <div className={styles.fieldset}>
                    <TextInput
                      className={styles.field}
                      label="Item name"
                      name="Item"
                      type="text"
                      placeholder='e. g. Redeemable Bitcoin Card with logo"'
                      onChange={handleItemName}
                      required
                    />
                    <TextInput
                      className={styles.field}
                      label="Description"
                      name="Description"
                      type="text"
                      placeholder="e. g. “After purchasing you will able to recived the logo...”"
                      onChange={handleDesc}
                      required
                    />
                    <div className={styles.row}>
                      <div className={styles.col}>
                        <div className={styles.field}>
                          <div className={styles.label}>Royalties</div>
                          <Dropdown
                            className={styles.dropdown}
                            value={royalties}
                            setValue={setRoyalties}
                            options={royaltiesOptions}
                          />
                        </div>
                      </div>
                      <div className={styles.col}>
                        <TextInput
                          className={styles.field}
                          label="Size"
                          name="Size"
                          type="text"
                          placeholder="e. g. Size"
                          required
                        />
                      </div>
                      <div className={styles.col}>
                        <TextInput
                          className={styles.field}
                          label="Propertie"
                          name="Propertie"
                          type="text"
                          placeholder="e. g. Propertie"
                          required
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div className={styles.options}>
                <div className={styles.option}>
                  <div className={styles.box}>
                    <div className={styles.category}>Put on sale</div>
                    <div className={styles.text}>
                      You’ll receive bids on this item
                    </div>
                  </div>
                  <Switch value={sale} setValue={setSale} />
                </div>
                <div className={styles.option}>
                  <div className={styles.box}>
                    <div className={styles.category}>Instant sale price</div>
                    <div className={styles.text}>
                      Enter the price for which the item will be instantly sold
                    </div>
                  </div>
                  <Switch value={price} setValue={setPrice} />
                </div>
                <div className={styles.option}>
                  <div className={styles.box}>
                    <div className={styles.category}>Unlock once purchased</div>
                    <div className={styles.text}>
                      Content will be unlocked after successful transaction
                    </div>
                  </div>
                  <Switch value={locking} setValue={setLocking} />
                </div>
                <div className={styles.category}>Choose collection</div>
                <div className={styles.text}>
                  Choose an exiting collection or create a new one
                </div>
                <Cards className={styles.cards} items={items} />
              </div>
              <div className={styles.foot}>
                <button
                  className={cn('button-stroke tablet-show', styles.button)}
                  onClick={() => setVisiblePreview(true)}
                  type="button"
                >
                  Preview
                </button>
                <button
                  className={cn('button', styles.button)}
                  onClick={() => setVisibleModal(true)}
                  // type="button" hide after form customization
                  type="button"
                >
                  <span onClick={onMint}>Create item</span>
                  <Icon name="arrow-next" size="10" />
                </button>
                <div className={styles.saving}>
                  <span>Auto saving</span>
                  <Loader className={styles.loader} />
                </div>
              </div>
            </form>
          </div>
          <Preview
            userFile={userFile}
            nftName={itemName}
            className={cn(styles.preview)}
            onClose={() => setVisiblePreview(false)}
          />
        </div>
      </div>
      <Modal visible={visibleModal} onClose={() => setVisibleModal(false)}>
        <FolowSteps className={styles.steps} />
      </Modal>
    </>
  )
}

export default UploadSingle
