using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.Networking;

public class ImageQuadController : MonoBehaviour
{
    Texture2D defaultTexture;
    // Start is called before the first frame update
    void Start()
    {
        defaultTexture = (Texture2D)this.gameObject.GetComponent<Renderer>().material.mainTexture;   
    }

    public void ResetImage(){
        this.gameObject.GetComponent<Renderer>().material.mainTexture = defaultTexture;
    }

    public IEnumerator ShowImage(string url){
        var imageQuad = this.gameObject;
        UnityWebRequest www = UnityWebRequestTexture.GetTexture(url);
        yield return www.SendWebRequest();
        try{
            Texture2D tex = ((DownloadHandlerTexture)www.downloadHandler).texture;
            imageQuad.GetComponent<Renderer>().material.mainTexture = tex;

            float Obj_x = imageQuad.transform.lossyScale.x;
            float Obj_y = imageQuad.transform.lossyScale.y;
            float Img_x = (float)tex.width;
            float Img_y = (float)tex.height;

            float aspectRatio_Obj = Obj_x / Obj_y;
            float aspectRatio_Img = Img_x/Img_y;

            if (aspectRatio_Img> aspectRatio_Obj)
            {
                //イメージサイズのほうが横に長い場合
                imageQuad.GetComponent<Renderer>().material.SetTextureScale("_MainTex", new Vector2(aspectRatio_Obj / aspectRatio_Img, 1f));
                imageQuad.GetComponent<Renderer>().material.SetTextureOffset("_MainTex", new Vector2(   (Img_x-(Obj_x*Img_y/Obj_y))/(2*Img_x)         , 1f));
            }
            else
            {
                //イメージサイズのほうが縦に長い場合
                imageQuad.GetComponent<Renderer>().material.SetTextureScale("_MainTex", new Vector2(1f,  aspectRatio_Img/ aspectRatio_Obj));
                imageQuad.GetComponent<Renderer>().material.SetTextureOffset("_MainTex", new Vector2(1f,  (Img_y-Obj_y*Img_x/Obj_x)/(2*Img_y)          ));
            }


        }
        catch(Exception e){
            var nonusable = FlyingText.GetObject("画像出力エラー");
            nonusable.AddComponent<TextObject>();
            Debug.Log(e);
        }
    }
}
