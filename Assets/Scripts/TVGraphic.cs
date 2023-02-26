using System.Collections;
using UnityEngine;

//https://www.youtube.com/watch?v=RH2xniNyYkU
//http://paulbourke.net/fractals/peterdejong/
public class TVGraphic : MonoBehaviour
{
    int width;
    int height;
    Texture2D tvTexture;
    Texture2D defaultTexture;
    Color[] buffer;
    int[,] countMap;
    int totalCount = 0;

    float a,b,c,d,x,y;
    // Start is called before the first frame update
    void Start()
    {
        defaultTexture = (Texture2D)this.gameObject.GetComponent<Renderer>().material.mainTexture;
        Init();
    }
    void Init(){

        Texture2D maintexture = defaultTexture;
        Color[] pixels = maintexture.GetPixels();

        buffer = new Color[pixels.Length];
        pixels.CopyTo(buffer, 0);

        width = maintexture.width;
        height = maintexture.height;

        tvTexture = new Texture2D(width,height,TextureFormat.RGBA32, false);
        tvTexture.filterMode = FilterMode.Bilinear;
        Generate();
    }
    void Generate(){
        a = UnityEngine.Random.Range(-3.0f,3.0f);
        b = UnityEngine.Random.Range(-3.0f,3.0f);
        c = UnityEngine.Random.Range(-3.0f,3.0f);
        d = UnityEngine.Random.Range(-3.0f,3.0f);
        x = 0;
        y = 0;
        countMap = new int[width,height];
        totalCount = 0;
    }

    void Step(){
        var nx = Mathf.Sin(a * y) - Mathf.Cos(b * x);
        var ny = Mathf.Sin(c * x) - Mathf.Cos(d * y);

        x = nx;
        y = ny;

        int px = (int)Mathf.Floor((x + 2) / 4 * width);
        int py = (int)Mathf.Floor((y + 2) / 4 * height);
        
        // buffer.SetValue(Color.white, px+256*py);
        countMap[px,py] += 1;
        totalCount++;
    }
    void Plot(){
        int count = 0;
        for(int j = 0; j < height; j++){
            for(int i = 0; i < width; i++){
                float ratio = ((float)countMap[i,j] / (float)totalCount) *width;
                if(ratio > 0){
                    // buffer.SetValue(Color.white, i+j*256);
                    float l = Mathf.Pow(1f - ratio, 100);
                    float k = 1.0f - l;
                    var setcolor = new Color(k, 1, 1, k);
                    buffer.SetValue(setcolor, i+j*256);
                    if( k > 0.1){
                        count++;
                    }
                }
            }
        }
        if(count < width * height * 0.01){
            StartCoroutine(Draw());
        }
    }
    public IEnumerator Draw(){
        Init(); 
        yield return new WaitForSeconds(1.0f);
        
        for (int i = 0; i < 100000; i++){
            Step();
        }
        
        Plot();
        tvTexture.SetPixels(buffer);
        tvTexture.Apply();
        this.gameObject.GetComponent<Renderer>().material.mainTexture = tvTexture;
    }
    

}
