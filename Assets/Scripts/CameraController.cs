using UnityEngine;

/// <summary>
/// Контролер камери для 2D гри
/// Слідкує за гравцем або дозволяє рухати камеру за допомогою WASD
/// </summary>
public class CameraController : MonoBehaviour
{
    [Header("Налаштування камери")]
    [SerializeField] private Transform target; // Ціль для слідування (гравець)
    [SerializeField] private float smoothSpeed = 0.125f;
    [SerializeField] private Vector3 offset = new Vector3(0, 0, -10);
    [SerializeField] private float minX = -100f;
    [SerializeField] private float maxX = 100f;
    [SerializeField] private float minY = -100f;
    [SerializeField] private float maxY = 100f;
    
    [Header("Налаштування руху камери")]
    [SerializeField] private float cameraMoveSpeed = 5f;
    [SerializeField] private bool allowCameraMovement = true;
    
    private void Start()
    {
        if (target == null)
        {
            // Спробуємо знайти гравця
            target = GameObject.FindGameObjectWithTag("Player").transform;
        }
    }
    
    private void LateUpdate()
    {
        if (target != null)
        {
            // Слідуємо за гравцем
            Vector3 desiredPosition = target.position + offset;
            Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed);
            transform.position = smoothedPosition;
        }
        else if (allowCameraMovement)
        {
            // Рух камери за допомогою WASD (якщо немає цілі)
            float horizontal = Input.GetAxis("Horizontal");
            float vertical = Input.GetAxis("Vertical");
            
            Vector3 movement = new Vector3(horizontal, vertical, 0) * cameraMoveSpeed * Time.deltaTime;
            Vector3 newPosition = transform.position + movement;
            
            // Обмежуємо рух камери
            newPosition.x = Mathf.Clamp(newPosition.x, minX, maxX);
            newPosition.y = Mathf.Clamp(newPosition.y, minY, maxY);
            
            transform.position = newPosition;
        }
        
        // Обмежуємо позицію камери межами
        transform.position = new Vector3(
            Mathf.Clamp(transform.position.x, minX, maxX),
            Mathf.Clamp(transform.position.y, minY, maxY),
            transform.position.z
        );
    }
    
    /// <summary>
    /// Встановити ціль для слідування
    /// </summary>
    public void SetTarget(Transform newTarget)
    {
        target = newTarget;
    }
    
    /// <summary>
    /// Увімкнути/вимкнути рух камери
    /// </summary>
    public void SetCameraMovement(bool enabled)
    {
        allowCameraMovement = enabled;
    }
    
    /// <summary>
    /// Встановити межі камери
    /// </summary>
    public void SetBounds(float minX, float maxX, float minY, float maxY)
    {
        this.minX = minX;
        this.maxX = maxX;
        this.minY = minY;
        this.maxY = maxY;
    }
}
