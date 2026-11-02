const http = require('http');

async function runTests() {
  console.log('Testing Together Server endpoints...');

  const post = (path, body) => new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = http.request({
      hostname: '127.0.0.1',
      port: 4000,
      path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    }, res => {
      let resp = '';
      res.on('data', chunk => resp += chunk);
      res.on('end', () => resolve(JSON.parse(resp)));
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });

  const get = (path) => new Promise((resolve, reject) => {
    http.get(`http://127.0.0.1:4000${path}`, res => {
      let resp = '';
      res.on('data', chunk => resp += chunk);
      res.on('end', () => resolve(JSON.parse(resp)));
    }).on('error', reject);
  });

  // Health check
  const health = await get('/health');
  console.log('Health check:', health);

  // 1. Create Couple Space
  const createCouple = await post('/api/couples/create', {
    partner1Name: 'Alex',
    anniversaryDate: '2023-08-18',
    relationshipStatus: 'Madly In Love ❤️'
  });
  console.log('Created couple space:', createCouple.couple.space_code, 'ID:', createCouple.couple.id);
  const coupleId = createCouple.couple.id;
  const spaceCode = createCouple.couple.space_code;

  // 2. Partner 2 joins
  const joinRes = await post('/api/couples/join', {
    spaceCode,
    partner2Name: 'Sam'
  });
  console.log('Partner 2 joined:', joinRes.couple.partner2_name);

  // 3. Daily Question & Answering
  const dailyQ = await get(`/api/questions/${coupleId}/daily`);
  console.log('Daily Question:', dailyQ.question_text);

  const p1Ans = await post(`/api/questions/${coupleId}/answer`, {
    questionId: dailyQ.id,
    partner: 'partner1',
    answer: 'Seeing you laugh during our late night drives.'
  });
  console.log('P1 Answered. Revealed?', p1Ans.is_revealed);

  const p2Ans = await post(`/api/questions/${coupleId}/answer`, {
    questionId: dailyQ.id,
    partner: 'partner2',
    answer: 'When you surprised me with handwritten notes!'
  });
  console.log('P2 Answered. Revealed?', p2Ans.is_revealed);

  // 4. Interconnected: Convert Q&A to Journal
  const journalConversion = await post(`/api/questions/${coupleId}/${dailyQ.id}/to-journal`, {
    authorPartner: 'both'
  });
  console.log('Converted Q&A to Journal:', journalConversion.journalEntry.title);

  // 5. Send Cute Message (Hug)
  const hug = await post(`/api/cute-messages/${coupleId}/send`, {
    senderPartner: 'partner1',
    messageType: 'hug',
    content: 'Warmest bear hug for you!'
  });
  console.log('Sent Cute Message:', hug.message_type);

  // 6. Wishlist to Date Plan
  const wishItem = await post(`/api/wishlist/${coupleId}`, {
    title: 'Sunset Picnic at Starlight Park',
    category: 'experience',
    notes: 'Bring sourdough bread, cheese, and portable speaker',
    priority: 'high'
  });
  console.log('Wishlist created:', wishItem.title);

  const planConv = await post(`/api/wishlist/${coupleId}/${wishItem.id}/to-plan`, {
    startDate: '2026-11-15',
    notes: 'Pack cozy blanket'
  });
  console.log('Converted Wishlist to Date Plan:', planConv.plan.title, planConv.plan.start_date);

  // 7. Plan to Memory
  const memConv = await post(`/api/plans/${coupleId}/${planConv.plan.id}/to-memory`, {
    caption: 'Best picnic ever with the most breathtaking sunset view!',
    photoUrls: ['/uploads/picnic_sunset.jpg']
  });
  console.log('Converted Date Plan to Memory:', memConv.memory.title);

  // 8. Turn-based game turn
  const games = await get(`/api/games/${coupleId}`);
  console.log(`Found ${games.length} seeded games`);
  const wyr = games.find(g => g.game_type === 'would_you_rather');
  if (wyr) {
    const turn1 = await post(`/api/games/${coupleId}/${wyr.id}/turn`, {
      partner: 'partner1',
      moveData: { choice: 'A', guess: 'B' }
    });
    console.log('P1 took turn in WYR. Turn now:', turn1.current_turn_partner);
    const turn2 = await post(`/api/games/${coupleId}/${wyr.id}/turn`, {
      partner: 'partner2',
      moveData: { choice: 'A', guess: 'A' }
    });
    console.log('P2 took turn in WYR. Status:', turn2.status, 'Streak:', turn2.streak_count);
  }

  // 9. Sync check
  const sync = await get(`/api/sync/${coupleId}`);
  console.log('Sync check summary:', {
    couple: sync.couple.partner1_name + ' & ' + sync.couple.partner2_name,
    questions: sync.questions.length,
    games: sync.games.length,
    plans: sync.plans.length,
    memories: sync.memories.length,
    journalEntries: sync.journalEntries.length,
    wishlist: sync.wishlist.length
  });

  console.log('\nALL BACKEND API TESTS PASSED SUCCESSFULLY! ✅');
  process.exit(0);
}

runTests().catch(err => {
  console.error('Test failed:', err);
  process.exit(1);
});
