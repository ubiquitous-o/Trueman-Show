using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ChatNode : MonoBehaviour
{
    [SerializeField]
    Image usernameImage;
    [SerializeField]
    TMP_Text usernameText;

    [SerializeField]
    TMP_Text msgText;

    [SerializeField]
    LayoutGroup layoutGroup;
    public void Init(string name, string msg){
        try{

            if (name == "k-chan"){
                usernameImage.color = new Color32(144, 238, 144, 255);
                usernameText.text = "ケイ";
                usernameText.color = new Color32(0, 0, 0,255);
                msgText.text = msg;
                layoutGroup.childAlignment = TextAnchor.MiddleRight;
                usernameImage.transform.SetSiblingIndex(1);
            }
            else{
                var color = NameToUniqueColor(name);

                usernameImage.color = color;
                usernameText.text = name;
                msgText.text = msg;
                layoutGroup.childAlignment = TextAnchor.MiddleLeft;
                usernameImage.transform.SetSiblingIndex(0);
            }
        }
        catch(Exception e){
            Debug.Log(e);
            Destroy(this.gameObject);
        }
    }

    private Color NameToUniqueColor(string name){
        var data = System.Text.Encoding.UTF8.GetBytes(name);
        string str = "";
        for (int i = 0; i < data.Length; i++) {
            str += string.Format("{0:X2}",data[i]);
        }
        int num = 0;
        int r = 0;
        int g = 0;
        int b = 0;
        var cnt = str.Length / 3;
        for (int i = 0; i < cnt -1; i++){
            if(int.TryParse(str[i].ToString(), out num)){
                r += num;   
            }
        }
        for (int i = cnt; i < cnt+cnt -1; i++){
            if(int.TryParse(str[i].ToString(), out num)){
                g += num;
            }
        }
        for (int i = cnt+cnt; i < cnt+cnt+cnt; i++){
            if(int.TryParse(str[i].ToString(), out num)){
                b += num;
            }
        }
        if (r < 100){
            if(r > 50){
                r = r * 2;
            }
            else{
                r = r * 4;
            }

            if(r > 255){
                r = 255;
            }
        }
        if (g < 100){
            if(g > 50){
                g = g * 2;
            }
            else{
                g = g * 4;
            }
            if(g > 255){
                g = 255;
            }
        }
        if (b < 100){
            if(b > 50){
                b = b * 2;
            }
            else{
                b = b * 4;
            }
            if(b > 255){
                b = 255;
            }
        }
        var color = new Color32((byte)r, (byte)g, (byte)b, 255);
        Debug.Log(color);
        return color;
    }
    void Update(){
        var pos = this.gameObject.GetComponent<RectTransform>().position;
        //TODO: もうちょっといい感じに消す処理したい。
        if(pos.y > 1400){
            Destroy(this.gameObject);
        }
    }
}
