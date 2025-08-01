import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { TonClient, WalletContractV4, internal, toNano } from 'ton';
import { mnemonicToPrivateKey } from 'ton-crypto';

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

app.post('/generate-boc', async (req, res) => {
  const { toAddress, amount } = req.body;

  try {
    const mnemonic = process.env.MNEMONIC.split(' ');
    const keyPair = await mnemonicToPrivateKey(mnemonic);

    const client = new TonClient({ endpoint: 'https://toncenter.com/api/v2/jsonRPC' });

    const wallet = WalletContractV4.create({ workchain: 0, publicKey: keyPair.publicKey });
    const walletContract = client.open(wallet);

    const seqno = await walletContract.getSeqno();

    const transfer = await walletContract.createTransfer({
      seqno,
      secretKey: keyPair.secretKey,
      sendMode: 3,
      messages: [
        internal({
          to: toAddress,
          value: toNano(amount),
          body: null
        })
      ]
    });

    const boc = transfer.toBoc().toString('base64');
    res.json({ boc });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to generate BOC' });
  }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`BOC server running at http://localhost:${PORT}`));
