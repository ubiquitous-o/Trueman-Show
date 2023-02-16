using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class SimpleMsg : MonoBehaviour
{
    [SerializeField,TextArea(1,10)]
    string user;
    [SerializeField,TextArea(1,10)]
    string msg;

    [SerializeField]
    bool isSuper;

    [SerializeField,TextArea(1,10)]
    string superAmount;

    [SerializeField,TextArea(1,10)]
    string superMsg;
    [SerializeField]
    bool isOwner;


    [Button("Send")]
    public bool sendbutton;
    
    MessageController m;
    
    
    void Start(){
        m = GetComponent<MessageController>();
    }
    public void Send(){
        var msgFormat = new MsgFormat();
        msgFormat.user = user;
        msgFormat.msg = msg;
        msgFormat.isSuper = isSuper;
        msgFormat.superAmount = superAmount;
        msgFormat.superMsg = superMsg;
        msgFormat.isOwner = isOwner;
        m.SwitchCmd(msgFormat);
    }
}