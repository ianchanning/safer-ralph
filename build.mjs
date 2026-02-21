import MarkdownIt from 'markdown-it';
import fs from 'fs/promises';

const md = new MarkdownIt({
  html: true,
});

async function build() {
  try {
    const layout = await fs.readFile('_layout.html', 'utf-8');
    const contentMd = await fs.readFile('index.md', 'utf-8');
    
    const contentHtml = md.render(contentMd);
    
    const finalHtml = layout.replace('{{content}}', contentHtml);
    
    await fs.writeFile('index.html', finalHtml);
    console.log('Successfully built index.html');
  } catch (error) {
    console.error('Error building index.html:', error);
    process.exit(1);
  }
}

build();
