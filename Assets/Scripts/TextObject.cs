using UnityEngine;

public class TextObject : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var r = Random.value;
        var g = Random.value;
        var b = Random.value;
        var rndcolor = new Color(r,g,b);
    
        this.gameObject.GetComponent<MeshRenderer>().material.color = rndcolor;

        int rnd = Random.Range(1, 10);
        this.gameObject.transform.position = new Vector3(-5.0f, rnd, 0.0f);
        this.gameObject.transform.rotation = new Quaternion(0,180,0,0);
        
        Destroy(this.gameObject, 20.0f);

    }

    void Update()
    {
        var pos = this.gameObject.transform.position;
        pos.x += 0.03f;
        this.gameObject.transform.position = pos;
    }

}
