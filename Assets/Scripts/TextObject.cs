using UnityEngine;

public class TextObject : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var r = Random.Range(100,200);
        var g = Random.Range(100,200);
        var b = Random.Range(100,200);
        var rndcolor = new Color32((byte)r,(byte)g,(byte)b,255);
    
        this.gameObject.GetComponent<MeshRenderer>().material.color = rndcolor;

        int rndy = Random.Range(0, 8);
        int rndz = Random.Range(4, 12);
        this.gameObject.transform.position = new Vector3(-15.0f, rndy, rndz);
        this.gameObject.transform.rotation = new Quaternion(0,0,0,0);
        this.gameObject.transform.localScale = new Vector3(2,2,2);
        this.gameObject.layer = 8;
        Destroy(this.gameObject, 10.0f);

    }

    void Update()
    {
        var pos = this.gameObject.transform.position;
        pos.x += 0.03f;
        this.gameObject.transform.position = pos;
    }

}
