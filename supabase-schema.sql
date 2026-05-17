-- ============================================================
-- HIPCOM WORKSPACE — Schema do banco de dados (Supabase)
-- Cole este SQL no Supabase > SQL Editor > New Query > Run
-- ============================================================

-- PROJETOS
create table if not exists projetos (
  id          uuid primary key default gen_random_uuid(),
  nome        text not null,
  segmento    text,
  status      text default 'levantamento',
  cidade      text,
  uf          text,
  responsavel text,
  contato     text,
  data_inicio date,
  data_golive date,
  obs         text,
  fases       jsonb default '{}',
  criado_em   timestamptz default now(),
  atualizado_em timestamptz default now()
);

-- ANOTAÇÕES
create table if not exists notas (
  id          uuid primary key default gen_random_uuid(),
  titulo      text,
  corpo       text,
  tipo        text default 'geral',
  projeto_id  uuid references projetos(id) on delete set null,
  criado_em   timestamptz default now(),
  atualizado_em timestamptz default now()
);

-- CLIENTES
create table if not exists clientes (
  id          uuid primary key default gen_random_uuid(),
  nome        text not null,
  segmento    text,
  uf          text,
  contato     text,
  telefone    text,
  email       text,
  criado_em   timestamptz default now()
);

-- PENDÊNCIAS
create table if not exists pendencias (
  id          uuid primary key default gen_random_uuid(),
  projeto_id  uuid references projetos(id) on delete set null,
  descricao   text not null,
  responsavel text,
  status      text default 'aberto',
  criado_em   timestamptz default now()
);

-- BASE DE CONHECIMENTO
create table if not exists base_conhecimento (
  id          uuid primary key default gen_random_uuid(),
  titulo      text not null,
  categoria   text default 'Geral',
  conteudo    text,
  criado_em   timestamptz default now()
);

-- Trigger para atualizar atualizado_em automaticamente
create or replace function update_atualizado_em()
returns trigger as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_projetos before update on projetos
  for each row execute function update_atualizado_em();

create trigger trg_notas before update on notas
  for each row execute function update_atualizado_em();

-- RLS: deixa tudo acessível publicamente para a equipe interna
-- (para produção com login, substituir por políticas por usuário)
alter table projetos          enable row level security;
alter table notas             enable row level security;
alter table clientes          enable row level security;
alter table pendencias        enable row level security;
alter table base_conhecimento enable row level security;

create policy "acesso_total" on projetos          for all using (true) with check (true);
create policy "acesso_total" on notas             for all using (true) with check (true);
create policy "acesso_total" on clientes          for all using (true) with check (true);
create policy "acesso_total" on pendencias        for all using (true) with check (true);
create policy "acesso_total" on base_conhecimento for all using (true) with check (true);
