using UnityEngine;

using System.Net;
using System.Net.Sockets;
using System.Text;

using UniRx;

[System.Serializable]
public class MsgFormat{
    public string user;
    public string msg;
    public bool isSuper;
    public string superAmount;
    public string superMsg;
    public bool isOwner;
}

public class UdpManager : MonoBehaviour
{
    int PORT = 50007;

    private Subject<MsgFormat> subject = new Subject<MsgFormat>();
    static UdpClient udpClient;
    // IPEndPoint remoteEP = null
    private MessageController messageController;

    // Start is called before the first frame update
    void Start()
    {
        udpClient = new UdpClient(PORT);
        udpClient.BeginReceive(OnReceived, udpClient);
        messageController = GetComponent<MessageController>();
        
        subject
           .ObserveOnMainThread()
           .Subscribe(data => {
                messageController.SwitchCmd(data);
           }).AddTo(this);
    }

    private void OnReceived(System.IAsyncResult result) {
        UdpClient getUdp = (UdpClient) result.AsyncState;
        IPEndPoint ipEnd = null;

        byte[] getByte = getUdp.EndReceive(result, ref ipEnd);
        var message = Encoding.UTF8.GetString(getByte);
        MsgFormat msgFormat = JsonUtility.FromJson<MsgFormat>(message);
        subject.OnNext(msgFormat);
        getUdp.BeginReceive(OnReceived, getUdp);
    } 

    void OnDestroy()
    {
        udpClient.Close();
    }
}
