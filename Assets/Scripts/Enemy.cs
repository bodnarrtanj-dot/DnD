using UnityEngine;

/// <summary>
/// Клас ворога для D&D гри
/// </summary>
public class Enemy : MonoBehaviour
{
    [Header("Характеристики ворога")]
    [SerializeField] private string enemyName = "Монстр";
    [SerializeField] private string enemyType = "Гоблін";
    [SerializeField] private int health = 10;
    [SerializeField] private int maxHealth = 10;
    [SerializeField] private int attack = 5;
    [SerializeField] private int defense = 2;
    [SerializeField] private int xpReward = 20;
    [SerializeField] private int goldReward = 10;
    
    [Header("Налаштування руху")]
    [SerializeField] private float moveSpeed = 2f;
    [SerializeField] private float chaseRange = 5f;
    [SerializeField] private float attackRange = 1.5f;
    
    private Transform player;
    private Rigidbody2D rb;
    private CombatSystem combatSystem;
    
    // Події
    public static event System.Action<Enemy> OnEnemyDefeated;
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        player = GameObject.FindGameObjectWithTag("Player").transform;
        combatSystem = FindObjectOfType<CombatSystem>();
    }
    
    private void Update()
    {
        if (player == null || combatSystem == null) return;
        
        // Перевіряємо відстань до гравця
        float distanceToPlayer = Vector2.Distance(transform.position, player.position);
        
        if (distanceToPlayer <= chaseRange)
        {
            // Переслідуємо гравця
            Vector2 direction = (player.position - transform.position).normalized;
            rb.velocity = direction * moveSpeed;
            
            // Якщо досить близько, атакуємо
            if (distanceToPlayer <= attackRange)
            {
                // Починаємо бій
                if (combatSystem.CurrentState == CombatSystem.CombatState.Idle)
                {
                    combatSystem.StartCombat(this);
                }
            }
        }
        else
        {
            // Стоїмо на місці
            rb.velocity = Vector2.zero;
        }
    }
    
    /// <summary>
    /// Завдати шкоди ворогу
    /// </summary>
    public void TakeDamage(int damage)
    {
        health -= damage;
        
        if (health <= 0)
        {
            Die();
        }
    }
    
    /// <summary>
    /// Смерть ворога
    /// </summary>
    private void Die()
    {
        OnEnemyDefeated?.Invoke(this);
        
        // Нагороджуємо гравця
        if (combatSystem != null)
        {
            combatSystem.currentState = CombatSystem.CombatState.Victory;
        }
        
        // Ефект смерті
        // Тут можна додати анімацію, звук тощо
        
        Destroy(gameObject);
    }
    
    // Getters та Setters
    public string Name => enemyName;
    public string Type => enemyType;
    public int Health => health;
    public int MaxHealth => maxHealth;
    public int Attack => attack;
    public int Defense => defense;
    public int XPReward => xpReward;
    public int GoldReward => goldReward;
}
